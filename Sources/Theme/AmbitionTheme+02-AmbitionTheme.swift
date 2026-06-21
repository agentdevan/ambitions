#if canImport(SwiftUI)
import SwiftUI

// AMBITIONS-QUALITY-EXTRACTION: AmbitionTheme remains a cohesive public token aggregate under the hard 600-line ceiling; nested public tokens stay together to preserve package API clarity.
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


    public struct PrimitiveSemanticColors: Sendable {
        public let source: Color
        public let sourceAttention: Color
        public let privacyBoundary: Color
        public let receipt: Color
        public let accessibilityFallbackSurface: Color
        public let accessibilityContrastStroke: Color
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


    public struct CanonSurfaces: Sendable {
        public let celestialField: Color
        public let celestialFieldDeep: Color
        public let graphiteRecess: Color
        public let quietGlass: Color
        public let hairline: Color
        public let luminousTrace: Color
        public let pressure: Color
        public let protectedTime: Color
        public let recovery: Color
        public let trust: Color
    }


    public struct CanonMaterials: Sendable {
        public let celestialField: LinearGradient
        public let graphiteRecess: LinearGradient
        public let luminousTrace: Color
        public let quietGlass: LinearGradient
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

        // Stable aliases for shared consumers.
        public var cardGradient: LinearGradient { elevatedGradient }
    }


    public struct ShellTokens: Sendable {
        public let canvasGradient: LinearGradient
        public let elevatedMaterial: LinearGradient
        public let headerMaterial: LinearGradient
        public let bottomBarMaterial: LinearGradient
        public let ribbonMaterial: LinearGradient
        public let receiptMaterial: LinearGradient
        public let glass: ShellGlassTokens
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


    public struct ShellGlassTokens: Sendable {
        public let controlGlass: Glass
        public let headerGlass: Glass
        public let bottomBarGlass: Glass
        public let containerSpacing: CGFloat
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
    public var primitiveSemanticColors: PrimitiveSemanticColors {
        PrimitiveSemanticColors(
            source: semanticColors.trust,
            sourceAttention: semanticColors.risk,
            privacyBoundary: semanticColors.protected,
            receipt: colors.accentWarm,
            accessibilityFallbackSurface: colors.surfaceOverlay,
            accessibilityContrastStroke: colors.strokeStrong
        )
    }

    public let borders: BorderTokens

    public let panel: PanelTokens

    public let tone: Tone

    public let materials: Materials

    public let surfaces: Surfaces

    public let shell: ShellTokens
    public var canonSurfaces: CanonSurfaces {
        CanonSurfaces(
            celestialField: colors.canvas,
            celestialFieldDeep: colors.canvasElevated,
            graphiteRecess: colors.surfacePrimary,
            quietGlass: colors.surfaceOverlay,
            hairline: colors.strokeSubtle,
            luminousTrace: colors.accentSecondary,
            pressure: colors.warning,
            protectedTime: semanticColors.protected,
            recovery: semanticColors.recovery,
            trust: semanticColors.trust
        )
    }

    public var canonMaterials: CanonMaterials {
        CanonMaterials(
            celestialField: materials.canvasGradient,
            graphiteRecess: materials.elevatedGradient,
            luminousTrace: colors.accentSecondary,
            quietGlass: materials.overlayGradient
        )
    }

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
#endif
