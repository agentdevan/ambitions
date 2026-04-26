#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionThemeMode: String, CaseIterable, Codable, Sendable {
    case dark
    case light
}

public enum AmbitionAccentFamily: String, CaseIterable, Codable, Sendable, Identifiable {
    case sage
    case blueGray
    case mutedGold
    case copper
    case sand

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .sage: "Sage"
        case .blueGray: "Blue Gray"
        case .mutedGold: "Muted Gold"
        case .copper: "Copper"
        case .sand: "Sand"
        }
    }
}

/// Shared theme surface for Ambitions SwiftUI UI.
///
/// Inject a theme at the app shell with `.ambitionTheme(theme)` and read it
/// inside reusable primitives with `@Environment(\.ambitionTheme)`.
public struct AmbitionTheme: Sendable {
    public struct AccentPalette: Sendable {
        public let primary: Color
        public let secondary: Color
        public let warm: Color
    }

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

    public struct NeutralPalette: Sendable {
        public let warmDarkBase: Color
        public let warmDarkElevated: Color
        public let warmDarkSubtle: Color
        public let warmLightBase: Color
        public let warmLightElevated: Color
        public let warmLightSubtle: Color
    }

    public struct SemanticColors: Sendable {
        public let confidenceHigh: Color
        public let confidenceMedium: Color
        public let confidenceLow: Color
        public let recovery: Color
        public let waiting: Color
        public let protected: Color
        public let focus: Color
        public let capture: Color
        public let trust: Color
        public let review: Color
        public let risk: Color
        public let calendarDerived: Color
        public let accessibilityVerified: Color
        public let accessibilityUnverified: Color
    }

    public struct BorderTokens: Sendable {
        public let hairline: Color
        public let quiet: Color
        public let emphasized: Color
        public let semanticOpacity: Double
        public let selectedWidth: CGFloat
    }

    public struct PanelTokens: Sendable {
        public let heroRadius: CGFloat
        public let standardRadius: CGFloat
        public let compactRadius: CGFloat
        public let heroPadding: CGFloat
        public let standardPadding: CGFloat
        public let compactPadding: CGFloat
        public let minimumTapTarget: CGFloat
        public let visualSlotMinimumHeight: CGFloat
        public let timelineDotSize: CGFloat
    }

    public struct Tone: Sendable {
        public let canvasBase: Color
        public let canvasWash: Color
        public let heroStart: Color
        public let heroMiddle: Color
        public let heroEnd: Color
        public let elevatedStart: Color
        public let elevatedEnd: Color
        public let bandStart: Color
        public let bandEnd: Color
        public let overlayTint: Color
    }

    public struct Materials: Sendable {
        public let canvasGradient: LinearGradient
        public let elevatedGradient: LinearGradient
        public let overlayGradient: LinearGradient
        public let heroGradient: LinearGradient
        public let bandGradient: LinearGradient
        public let widgetGradient: LinearGradient
        public let successGradient: LinearGradient
        public let warningGradient: LinearGradient
        public let celebrationGradient: LinearGradient
    }

    public struct Surfaces: Sendable {
        public let canvasGradient: LinearGradient
        public let elevatedGradient: LinearGradient
        public let overlayGradient: LinearGradient
        public let heroGradient: LinearGradient
        public let bandGradient: LinearGradient
        public let widgetGradient: LinearGradient
        public let successGradient: LinearGradient
        public let warningGradient: LinearGradient
        public let celebrationGradient: LinearGradient
        public let topStrokeOpacity: Double
        public let bottomStrokeOpacity: Double
        public let backgroundBlurOpacity: Double

        // Compatibility aliases for earlier shared consumers.
        public var cardGradient: LinearGradient { elevatedGradient }
    }

    public struct ShellTokens: Sendable {
        public let canvasGradient: LinearGradient
        public let elevatedMaterial: LinearGradient
        public let headerMaterial: LinearGradient
        public let bottomBarMaterial: LinearGradient
        public let ribbonMaterial: LinearGradient
        public let receiptMaterial: LinearGradient
        public let activeTabForeground: Color
        public let activeTabBackground: Color
        public let inactiveTabForeground: Color
        public let controlForeground: Color
        public let controlBackground: Color
        public let divider: Color
        public let depthAccent: Color
        public let statusClear: Color
        public let statusSteady: Color
        public let statusTight: Color
        public let statusFragile: Color
        public let statusAtRisk: Color
        public let statusRecovered: Color
        public let statusProtected: Color
        public let trustBadgeSurface: Color
    }

    public struct Typography: Sendable {
        public init() {}

        public var heroDisplay: Font { .system(.largeTitle, design: .rounded).weight(.bold) }
        public var hero: Font { heroDisplay }
        public var title: Font { .system(.title2, design: .rounded).weight(.bold) }
        public var titleCompact: Font { .system(.title3, design: .rounded).weight(.semibold) }
        public var sectionTitle: Font { .system(.headline, design: .rounded).weight(.semibold) }
        public var section: Font { sectionTitle }
        public var bodyPrimary: Font { .system(.body, design: .default) }
        public var body: Font { bodyPrimary }
        public var bodySecondary: Font { .system(.subheadline, design: .default) }
        public var bodyEmphasized: Font { .system(.body, design: .rounded).weight(.semibold) }
        public var caption: Font { .system(.caption, design: .rounded).weight(.medium) }
        public var meta: Font { .system(.caption, design: .rounded).weight(.medium) }
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

        // Semantic aliases for the design-spec rhythm.
        public var micro: CGFloat { xxxs }
        public var tight: CGFloat { xxs }
        public var compact: CGFloat { xs }
        public var standard: CGFloat { sm }
        public var heroInner: CGFloat { md }
        public var sectionBreak: CGFloat { lg }
        public var majorBreak: CGFloat { xl }
    }

    public struct Radius: Sendable {
        public init() {}

        public let sm: CGFloat = 12
        public let md: CGFloat = 18
        public let lg: CGFloat = 24
        public let xl: CGFloat = 30
        public let pill: CGFloat = 999
        public let chip: CGFloat = 16
        public let band: CGFloat = 22
    }

    public struct Shadow: Sendable {
        public let color: Color
        public let radius: CGFloat
        public let x: CGFloat
        public let y: CGFloat
    }

    public struct Depth: Sendable {
        public let resting: Shadow
        public let raised: Shadow
        public let hero: Shadow
        public let overlay: Shadow
        public let pressedScale: CGFloat
        public let selectedScale: CGFloat
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

    public struct Timing: Sendable {
        public let quick: Double
        public let regular: Double
        public let emphasis: Double
        public let settle: Double
        public let route: Double
    }

    public struct Motion: Sendable {
        public let timing: Timing

        public var quick: Double { timing.quick }
        public var regular: Double { timing.regular }
        public var emphasis: Double { timing.emphasis }

        public func animation(reduceMotion: Bool, emphasis: Bool = false) -> Animation? {
            guard reduceMotion == false else { return nil }
            return .spring(
                response: emphasis ? timing.emphasis : timing.regular,
                dampingFraction: 0.86,
                blendDuration: timing.quick
            )
        }

        public func routeAnimation(reduceMotion: Bool) -> Animation? {
            guard reduceMotion == false else { return .easeOut(duration: 0.12) }
            return .spring(response: timing.route, dampingFraction: 0.88, blendDuration: timing.quick)
        }

        public func settleAnimation(reduceMotion: Bool) -> Animation? {
            guard reduceMotion == false else { return .easeOut(duration: 0.12) }
            return .easeOut(duration: timing.settle)
        }
    }

    public enum HapticIntent: String, CaseIterable, Sendable {
        case selection
        case completion
        case correction
        case reschedule
        case routeChange
        case warning
    }

    public struct Haptics: Sendable {
        public let enabled: Bool
        public let completion: HapticIntent
        public let correction: HapticIntent
        public let reschedule: HapticIntent
        public let routeChange: HapticIntent
        public let warning: HapticIntent
    }

    public let mode: AmbitionThemeMode
    public let accentFamily: AmbitionAccentFamily
    public let accentPalette: AccentPalette
    public let colors: Colors
    public let neutrals: NeutralPalette
    public let semanticColors: SemanticColors
    public let borders: BorderTokens
    public let panel: PanelTokens
    public let tone: Tone
    public let materials: Materials
    public let surfaces: Surfaces
    public let shell: ShellTokens
    public let typography: Typography
    public let spacing: Spacing
    public let radius: Radius
    public let depth: Depth
    public let elevation: Elevation
    public let glow: Glow
    public let icon: IconTreatment
    public let timing: Timing
    public let motion: Motion
    public let haptics: Haptics

    public init(
        mode: AmbitionThemeMode,
        accentFamily: AmbitionAccentFamily,
        accentPalette: AccentPalette,
        colors: Colors,
        neutrals: NeutralPalette,
        semanticColors: SemanticColors,
        borders: BorderTokens,
        panel: PanelTokens,
        tone: Tone,
        materials: Materials,
        surfaces: Surfaces,
        shell: ShellTokens,
        typography: Typography = Typography(),
        spacing: Spacing = Spacing(),
        radius: Radius = Radius(),
        depth: Depth,
        elevation: Elevation,
        glow: Glow,
        icon: IconTreatment,
        timing: Timing,
        motion: Motion,
        haptics: Haptics
    ) {
        self.mode = mode
        self.accentFamily = accentFamily
        self.accentPalette = accentPalette
        self.colors = colors
        self.neutrals = neutrals
        self.semanticColors = semanticColors
        self.borders = borders
        self.panel = panel
        self.tone = tone
        self.materials = materials
        self.surfaces = surfaces
        self.shell = shell
        self.typography = typography
        self.spacing = spacing
        self.radius = radius
        self.depth = depth
        self.elevation = elevation
        self.glow = glow
        self.icon = icon
        self.timing = timing
        self.motion = motion
        self.haptics = haptics
    }
}

public extension AmbitionTheme {
    static func theme(
        for mode: AmbitionThemeMode,
        accentFamily: AmbitionAccentFamily = .sage
    ) -> AmbitionTheme {
        let accent = accentPalette(for: accentFamily, mode: mode)
        let neutrals = neutralPalette(for: mode)
        let colors = colors(for: mode, accent: accent)
        let semanticColors = semanticColors(for: mode, accent: accent)
        let tone = tone(for: mode, accent: accent)
        let materials = materials(for: mode, tone: tone)
        let spacing = Spacing()
        let radius = Radius()
        let timing = Timing(quick: 0.18, regular: 0.34, emphasis: 0.48, settle: 0.22, route: 0.42)
        let depth = depth(for: mode)
        let elevation = Elevation(
            resting: depth.resting,
            raised: depth.raised,
            hero: depth.hero,
            pressedScale: depth.pressedScale,
            selectedScale: depth.selectedScale
        )
        let surfaces = Surfaces(
            canvasGradient: materials.canvasGradient,
            elevatedGradient: materials.elevatedGradient,
            overlayGradient: materials.overlayGradient,
            heroGradient: materials.heroGradient,
            bandGradient: materials.bandGradient,
            widgetGradient: materials.widgetGradient,
            successGradient: materials.successGradient,
            warningGradient: materials.warningGradient,
            celebrationGradient: materials.celebrationGradient,
            topStrokeOpacity: mode == .dark ? 0.28 : 0.16,
            bottomStrokeOpacity: mode == .dark ? 0.10 : 0.08,
            backgroundBlurOpacity: mode == .dark ? 0.84 : 0.96
        )
        let shell = shellTokens(for: mode, colors: colors, semanticColors: semanticColors, materials: materials, accent: accent)
        let glow = Glow(
            tint: accent.warm,
            radius: mode == .dark ? 18 : 16,
            opacity: mode == .dark ? 0.20 : 0.16,
            ringOpacity: mode == .dark ? 0.45 : 0.30
        )
        let borders = BorderTokens(
            hairline: colors.strokeSubtle,
            quiet: colors.strokeSubtle.opacity(mode == .dark ? 0.80 : 0.72),
            emphasized: colors.strokeStrong,
            semanticOpacity: mode == .dark ? 0.42 : 0.34,
            selectedWidth: 1.2
        )
        let panel = PanelTokens(
            heroRadius: radius.xl,
            standardRadius: radius.lg,
            compactRadius: radius.md,
            heroPadding: spacing.xl,
            standardPadding: spacing.lg,
            compactPadding: spacing.sm,
            minimumTapTarget: 44,
            visualSlotMinimumHeight: 96,
            timelineDotSize: 10
        )
        let icon = IconTreatment(
            smallSize: 15,
            mediumSize: 18,
            largeSize: 24,
            symbolWeight: .semibold,
            containerPadding: 10
        )
        let motion = Motion(timing: timing)
        let haptics = Haptics(
            enabled: true,
            completion: .completion,
            correction: .correction,
            reschedule: .reschedule,
            routeChange: .routeChange,
            warning: .warning
        )

        return AmbitionTheme(
            mode: mode,
            accentFamily: accentFamily,
            accentPalette: accent,
            colors: colors,
            neutrals: neutrals,
            semanticColors: semanticColors,
            borders: borders,
            panel: panel,
            tone: tone,
            materials: materials,
            surfaces: surfaces,
            shell: shell,
            depth: depth,
            elevation: elevation,
            glow: glow,
            icon: icon,
            timing: timing,
            motion: motion,
            haptics: haptics
        )
    }

    static let dark = theme(for: .dark)
    static let light = theme(for: .light)
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
            return .init(fill: colors.surfaceOverlay.opacity(1.3), stroke: accentColor.opacity(0.34), foreground: colors.textPrimary, accent: accentColor, glow: accentColor, opacity: 1, scale: depth.pressedScale)
        case .selected:
            return .init(fill: accentColor.opacity(0.18), stroke: accentColor.opacity(0.42), foreground: colors.textPrimary, accent: accentColor, glow: accentColor, opacity: 1, scale: depth.selectedScale)
        case .disabled:
            return .init(fill: colors.disabled, stroke: colors.strokeSubtle, foreground: colors.textTertiary, accent: colors.textTertiary, glow: colors.disabled, opacity: 0.55, scale: 1)
        case .loading:
            return .init(fill: colors.skeletonBase, stroke: colors.skeletonHighlight, foreground: colors.textSecondary, accent: colors.skeletonHighlight, glow: colors.skeletonHighlight, opacity: 1, scale: 1)
        case .success:
            return .init(fill: colors.success.opacity(0.18), stroke: colors.success.opacity(0.42), foreground: colors.textPrimary, accent: colors.success, glow: colors.success, opacity: 1, scale: 1)
        case .warning:
            return .init(fill: colors.warning.opacity(0.18), stroke: colors.warning.opacity(0.42), foreground: colors.textPrimary, accent: colors.warning, glow: colors.warning, opacity: 1, scale: 1)
        case .celebration:
            return .init(fill: colors.celebration.opacity(0.20), stroke: colors.celebration.opacity(0.44), foreground: colors.textPrimary, accent: colors.celebration, glow: colors.celebration, opacity: 1, scale: depth.selectedScale)
        }
    }
}

private extension AmbitionTheme {
    static func neutralPalette(for mode: AmbitionThemeMode) -> NeutralPalette {
        switch mode {
        case .dark:
            return .init(
                warmDarkBase: Color(red: 0.055, green: 0.060, blue: 0.070),
                warmDarkElevated: Color(red: 0.115, green: 0.118, blue: 0.135),
                warmDarkSubtle: Color(red: 0.155, green: 0.150, blue: 0.158),
                warmLightBase: Color(red: 0.965, green: 0.952, blue: 0.930),
                warmLightElevated: Color(red: 0.990, green: 0.982, blue: 0.962),
                warmLightSubtle: Color(red: 0.925, green: 0.910, blue: 0.885)
            )
        case .light:
            return .init(
                warmDarkBase: Color(red: 0.055, green: 0.060, blue: 0.070),
                warmDarkElevated: Color(red: 0.115, green: 0.118, blue: 0.135),
                warmDarkSubtle: Color(red: 0.155, green: 0.150, blue: 0.158),
                warmLightBase: Color(red: 0.965, green: 0.952, blue: 0.930),
                warmLightElevated: Color(red: 0.990, green: 0.982, blue: 0.962),
                warmLightSubtle: Color(red: 0.925, green: 0.910, blue: 0.885)
            )
        }
    }

    static func accentPalette(for family: AmbitionAccentFamily, mode: AmbitionThemeMode) -> AccentPalette {
        switch (family, mode) {
        case (.sage, .dark):
            .init(
                primary: Color(red: 0.47, green: 0.67, blue: 0.60),
                secondary: Color(red: 0.46, green: 0.60, blue: 0.86),
                warm: Color(red: 0.93, green: 0.66, blue: 0.40)
            )
        case (.sage, .light):
            .init(
                primary: Color(red: 0.28, green: 0.47, blue: 0.40),
                secondary: Color(red: 0.29, green: 0.45, blue: 0.74),
                warm: Color(red: 0.78, green: 0.52, blue: 0.27)
            )
        case (.blueGray, .dark):
            .init(
                primary: Color(red: 0.50, green: 0.63, blue: 0.84),
                secondary: Color(red: 0.55, green: 0.74, blue: 0.84),
                warm: Color(red: 0.84, green: 0.69, blue: 0.53)
            )
        case (.blueGray, .light):
            .init(
                primary: Color(red: 0.33, green: 0.45, blue: 0.66),
                secondary: Color(red: 0.42, green: 0.60, blue: 0.70),
                warm: Color(red: 0.71, green: 0.56, blue: 0.41)
            )
        case (.mutedGold, .dark):
            .init(
                primary: Color(red: 0.78, green: 0.63, blue: 0.37),
                secondary: Color(red: 0.60, green: 0.68, blue: 0.54),
                warm: Color(red: 0.92, green: 0.73, blue: 0.48)
            )
        case (.mutedGold, .light):
            .init(
                primary: Color(red: 0.58, green: 0.43, blue: 0.21),
                secondary: Color(red: 0.42, green: 0.56, blue: 0.40),
                warm: Color(red: 0.75, green: 0.58, blue: 0.33)
            )
        case (.copper, .dark):
            .init(
                primary: Color(red: 0.76, green: 0.48, blue: 0.36),
                secondary: Color(red: 0.71, green: 0.57, blue: 0.44),
                warm: Color(red: 0.92, green: 0.67, blue: 0.48)
            )
        case (.copper, .light):
            .init(
                primary: Color(red: 0.57, green: 0.33, blue: 0.22),
                secondary: Color(red: 0.57, green: 0.45, blue: 0.31),
                warm: Color(red: 0.76, green: 0.54, blue: 0.35)
            )
        case (.sand, .dark):
            .init(
                primary: Color(red: 0.73, green: 0.67, blue: 0.54),
                secondary: Color(red: 0.57, green: 0.66, blue: 0.60),
                warm: Color(red: 0.89, green: 0.76, blue: 0.56)
            )
        case (.sand, .light):
            .init(
                primary: Color(red: 0.55, green: 0.48, blue: 0.34),
                secondary: Color(red: 0.43, green: 0.54, blue: 0.50),
                warm: Color(red: 0.72, green: 0.62, blue: 0.41)
            )
        }
    }

    static func colors(for mode: AmbitionThemeMode, accent: AccentPalette) -> Colors {
        switch mode {
        case .dark:
            return .init(
                canvas: Color(red: 0.055, green: 0.060, blue: 0.070),
                canvasElevated: Color(red: 0.115, green: 0.118, blue: 0.135),
                canvasSubtle: Color(red: 0.155, green: 0.150, blue: 0.158),
                surfacePrimary: Color(red: 0.135, green: 0.135, blue: 0.155),
                surfaceSecondary: Color(red: 0.170, green: 0.165, blue: 0.180),
                surfaceOverlay: Color.white.opacity(0.08),
                textPrimary: Color(red: 0.95, green: 0.94, blue: 0.92),
                textSecondary: Color(red: 0.76, green: 0.76, blue: 0.73),
                textTertiary: Color(red: 0.58, green: 0.58, blue: 0.56),
                textInverse: Color(red: 0.10, green: 0.11, blue: 0.14),
                strokeSubtle: Color.white.opacity(0.08),
                strokeStrong: Color.white.opacity(0.16),
                accentPrimary: accent.primary,
                accentSecondary: accent.secondary,
                accentWarm: accent.warm,
                success: Color(red: 0.49, green: 0.79, blue: 0.60),
                warning: Color(red: 0.96, green: 0.71, blue: 0.41),
                celebration: Color(red: 1.00, green: 0.61, blue: 0.63),
                disabled: Color.white.opacity(0.18),
                skeletonBase: Color.white.opacity(0.06),
                skeletonHighlight: Color.white.opacity(0.16)
            )
        case .light:
            return .init(
                canvas: Color(red: 0.965, green: 0.952, blue: 0.930),
                canvasElevated: Color(red: 0.990, green: 0.982, blue: 0.962),
                canvasSubtle: Color(red: 0.925, green: 0.910, blue: 0.885),
                surfacePrimary: Color(red: 0.990, green: 0.982, blue: 0.962),
                surfaceSecondary: Color(red: 0.950, green: 0.936, blue: 0.912),
                surfaceOverlay: Color.black.opacity(0.03),
                textPrimary: Color(red: 0.10, green: 0.11, blue: 0.14),
                textSecondary: Color(red: 0.31, green: 0.33, blue: 0.37),
                textTertiary: Color(red: 0.48, green: 0.49, blue: 0.52),
                textInverse: Color.white,
                strokeSubtle: Color.black.opacity(0.08),
                strokeStrong: Color.black.opacity(0.14),
                accentPrimary: accent.primary,
                accentSecondary: accent.secondary,
                accentWarm: accent.warm,
                success: Color(red: 0.29, green: 0.57, blue: 0.39),
                warning: Color(red: 0.78, green: 0.50, blue: 0.20),
                celebration: Color(red: 0.82, green: 0.38, blue: 0.50),
                disabled: Color.black.opacity(0.12),
                skeletonBase: Color.black.opacity(0.05),
                skeletonHighlight: Color.black.opacity(0.12)
            )
        }
    }

    static func semanticColors(for mode: AmbitionThemeMode, accent: AccentPalette) -> SemanticColors {
        switch mode {
        case .dark:
            return .init(
                confidenceHigh: Color(red: 0.55, green: 0.76, blue: 0.62),
                confidenceMedium: Color(red: 0.86, green: 0.68, blue: 0.43),
                confidenceLow: Color(red: 0.86, green: 0.50, blue: 0.45),
                recovery: Color(red: 0.68, green: 0.62, blue: 0.88),
                waiting: Color(red: 0.68, green: 0.72, blue: 0.78),
                protected: Color(red: 0.78, green: 0.66, blue: 0.46),
                focus: accent.primary,
                capture: Color(red: 0.62, green: 0.74, blue: 0.82),
                trust: Color(red: 0.57, green: 0.71, blue: 0.70),
                review: Color(red: 0.80, green: 0.65, blue: 0.78),
                risk: Color(red: 0.88, green: 0.47, blue: 0.42),
                calendarDerived: Color(red: 0.48, green: 0.62, blue: 0.78),
                accessibilityVerified: Color(red: 0.54, green: 0.74, blue: 0.58),
                accessibilityUnverified: Color(red: 0.82, green: 0.62, blue: 0.38)
            )
        case .light:
            return .init(
                confidenceHigh: Color(red: 0.26, green: 0.52, blue: 0.36),
                confidenceMedium: Color(red: 0.66, green: 0.45, blue: 0.20),
                confidenceLow: Color(red: 0.68, green: 0.30, blue: 0.28),
                recovery: Color(red: 0.47, green: 0.39, blue: 0.68),
                waiting: Color(red: 0.43, green: 0.48, blue: 0.56),
                protected: Color(red: 0.60, green: 0.45, blue: 0.23),
                focus: accent.primary,
                capture: Color(red: 0.32, green: 0.52, blue: 0.62),
                trust: Color(red: 0.34, green: 0.55, blue: 0.53),
                review: Color(red: 0.58, green: 0.39, blue: 0.56),
                risk: Color(red: 0.67, green: 0.25, blue: 0.23),
                calendarDerived: Color(red: 0.31, green: 0.45, blue: 0.64),
                accessibilityVerified: Color(red: 0.28, green: 0.53, blue: 0.34),
                accessibilityUnverified: Color(red: 0.66, green: 0.44, blue: 0.18)
            )
        }
    }

    static func tone(for mode: AmbitionThemeMode, accent: AccentPalette) -> Tone {
        switch mode {
        case .dark:
            return .init(
                canvasBase: Color(red: 0.055, green: 0.060, blue: 0.070),
                canvasWash: accent.secondary.opacity(0.16),
                heroStart: accent.primary.opacity(0.34),
                heroMiddle: accent.secondary.opacity(0.18),
                heroEnd: Color(red: 0.125, green: 0.112, blue: 0.130),
                elevatedStart: Color(red: 0.165, green: 0.160, blue: 0.178),
                elevatedEnd: Color(red: 0.118, green: 0.118, blue: 0.135),
                bandStart: Color.white.opacity(0.07),
                bandEnd: accent.primary.opacity(0.08),
                overlayTint: Color.white.opacity(0.12)
            )
        case .light:
            return .init(
                canvasBase: Color(red: 0.965, green: 0.952, blue: 0.930),
                canvasWash: accent.secondary.opacity(0.08),
                heroStart: accent.primary.opacity(0.16),
                heroMiddle: accent.secondary.opacity(0.10),
                heroEnd: Color(red: 0.990, green: 0.982, blue: 0.962),
                elevatedStart: Color(red: 0.990, green: 0.982, blue: 0.962),
                elevatedEnd: Color(red: 0.950, green: 0.936, blue: 0.912),
                bandStart: Color.black.opacity(0.01),
                bandEnd: accent.primary.opacity(0.04),
                overlayTint: Color.black.opacity(0.04)
            )
        }
    }

    static func materials(for mode: AmbitionThemeMode, tone: Tone) -> Materials {
        switch mode {
        case .dark:
            return .init(
                canvasGradient: LinearGradient(colors: [tone.canvasWash, tone.canvasBase, tone.canvasBase], startPoint: .topLeading, endPoint: .bottomTrailing),
                elevatedGradient: LinearGradient(colors: [tone.elevatedStart, tone.elevatedEnd], startPoint: .topLeading, endPoint: .bottomTrailing),
                overlayGradient: LinearGradient(colors: [tone.overlayTint, tone.overlayTint.opacity(0.55)], startPoint: .top, endPoint: .bottom),
                heroGradient: LinearGradient(colors: [tone.heroStart, tone.heroMiddle, tone.heroEnd], startPoint: .topLeading, endPoint: .bottomTrailing),
                bandGradient: LinearGradient(colors: [tone.bandStart, tone.bandEnd], startPoint: .leading, endPoint: .trailing),
                widgetGradient: LinearGradient(colors: [Color(red: 0.21, green: 0.22, blue: 0.28), Color(red: 0.15, green: 0.16, blue: 0.20)], startPoint: .top, endPoint: .bottom),
                successGradient: LinearGradient(colors: [Color(red: 0.21, green: 0.33, blue: 0.27), Color(red: 0.15, green: 0.23, blue: 0.18)], startPoint: .topLeading, endPoint: .bottomTrailing),
                warningGradient: LinearGradient(colors: [Color(red: 0.34, green: 0.24, blue: 0.14), Color(red: 0.24, green: 0.17, blue: 0.11)], startPoint: .topLeading, endPoint: .bottomTrailing),
                celebrationGradient: LinearGradient(colors: [Color(red: 0.42, green: 0.22, blue: 0.29), Color(red: 0.23, green: 0.14, blue: 0.24)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        case .light:
            return .init(
                canvasGradient: LinearGradient(colors: [tone.canvasWash, tone.canvasBase, tone.canvasBase], startPoint: .topLeading, endPoint: .bottomTrailing),
                elevatedGradient: LinearGradient(colors: [tone.elevatedStart, tone.elevatedEnd], startPoint: .topLeading, endPoint: .bottomTrailing),
                overlayGradient: LinearGradient(colors: [tone.overlayTint, Color.white.opacity(0.72)], startPoint: .top, endPoint: .bottom),
                heroGradient: LinearGradient(colors: [tone.heroStart, tone.heroMiddle, tone.heroEnd], startPoint: .topLeading, endPoint: .bottomTrailing),
                bandGradient: LinearGradient(colors: [tone.bandStart, tone.bandEnd], startPoint: .leading, endPoint: .trailing),
                widgetGradient: LinearGradient(colors: [Color.white, Color(red: 0.95, green: 0.95, blue: 0.97)], startPoint: .top, endPoint: .bottom),
                successGradient: LinearGradient(colors: [Color(red: 0.86, green: 0.95, blue: 0.88), Color.white], startPoint: .topLeading, endPoint: .bottomTrailing),
                warningGradient: LinearGradient(colors: [Color(red: 0.98, green: 0.92, blue: 0.84), Color.white], startPoint: .topLeading, endPoint: .bottomTrailing),
                celebrationGradient: LinearGradient(colors: [Color(red: 0.98, green: 0.90, blue: 0.93), Color.white], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        }
    }

    static func shellTokens(
        for mode: AmbitionThemeMode,
        colors: Colors,
        semanticColors: SemanticColors,
        materials: Materials,
        accent: AccentPalette
    ) -> ShellTokens {
        switch mode {
        case .dark:
            return .init(
                canvasGradient: materials.canvasGradient,
                elevatedMaterial: materials.elevatedGradient,
                headerMaterial: materials.overlayGradient,
                bottomBarMaterial: LinearGradient(
                    colors: [
                        Color(red: 0.088, green: 0.096, blue: 0.122).opacity(0.98),
                        Color(red: 0.052, green: 0.058, blue: 0.074).opacity(0.98)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                ribbonMaterial: materials.bandGradient,
                receiptMaterial: materials.elevatedGradient,
                activeTabForeground: accent.warm,
                activeTabBackground: accent.warm.opacity(0.18),
                inactiveTabForeground: Color(red: 0.58, green: 0.66, blue: 0.74),
                controlForeground: colors.textPrimary,
                controlBackground: colors.surfaceOverlay,
                divider: colors.strokeSubtle,
                depthAccent: accent.secondary.opacity(0.22),
                statusClear: semanticColors.confidenceHigh,
                statusSteady: semanticColors.focus,
                statusTight: colors.warning,
                statusFragile: semanticColors.recovery,
                statusAtRisk: semanticColors.risk,
                statusRecovered: semanticColors.recovery,
                statusProtected: semanticColors.protected,
                trustBadgeSurface: semanticColors.trust.opacity(0.18)
            )
        case .light:
            return .init(
                canvasGradient: materials.canvasGradient,
                elevatedMaterial: materials.elevatedGradient,
                headerMaterial: materials.overlayGradient,
                bottomBarMaterial: LinearGradient(
                    colors: [
                        Color(red: 0.990, green: 0.982, blue: 0.962).opacity(0.98),
                        Color(red: 0.944, green: 0.928, blue: 0.900).opacity(0.98)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                ribbonMaterial: materials.bandGradient,
                receiptMaterial: materials.elevatedGradient,
                activeTabForeground: accent.warm,
                activeTabBackground: accent.warm.opacity(0.16),
                inactiveTabForeground: Color(red: 0.39, green: 0.45, blue: 0.52),
                controlForeground: colors.textPrimary,
                controlBackground: colors.surfaceOverlay,
                divider: colors.strokeSubtle,
                depthAccent: accent.secondary.opacity(0.12),
                statusClear: semanticColors.confidenceHigh,
                statusSteady: semanticColors.focus,
                statusTight: colors.warning,
                statusFragile: semanticColors.recovery,
                statusAtRisk: semanticColors.risk,
                statusRecovered: semanticColors.recovery,
                statusProtected: semanticColors.protected,
                trustBadgeSurface: semanticColors.trust.opacity(0.12)
            )
        }
    }

    static func depth(for mode: AmbitionThemeMode) -> Depth {
        switch mode {
        case .dark:
            return .init(
                resting: .init(color: Color.black.opacity(0.24), radius: 14, x: 0, y: 8),
                raised: .init(color: Color.black.opacity(0.32), radius: 22, x: 0, y: 14),
                hero: .init(color: Color.black.opacity(0.38), radius: 28, x: 0, y: 18),
                overlay: .init(color: Color.black.opacity(0.42), radius: 30, x: 0, y: 22),
                pressedScale: 0.985,
                selectedScale: 1.01
            )
        case .light:
            return .init(
                resting: .init(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5),
                raised: .init(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 10),
                hero: .init(color: Color.black.opacity(0.14), radius: 24, x: 0, y: 14),
                overlay: .init(color: Color.black.opacity(0.16), radius: 26, x: 0, y: 16),
                pressedScale: 0.99,
                selectedScale: 1.005
            )
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
