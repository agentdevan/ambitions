#if canImport(SwiftUI)
import SwiftUI

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
            backgroundBlurOpacity: 1.0
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

public enum AmbitionPrimitiveSemanticToken: String, CaseIterable, Identifiable, Sendable {
    case source = "primitive.source"
    case sourceAttention = "primitive.sourceAttention"
    case privacyBoundary = "primitive.privacyBoundary"
    case receipt = "primitive.receipt"
    case accessibilityFallbackSurface = "primitive.accessibilityFallbackSurface"
    case accessibilityContrastStroke = "primitive.accessibilityContrastStroke"

    public var id: String { rawValue }

    public var installedPrimitive: String {
        switch self {
        case .source, .sourceAttention, .privacyBoundary, .receipt:
            return "SourceTrustReceiptStrip"
        case .accessibilityFallbackSurface, .accessibilityContrastStroke:
            return "AmbitionsPrimitiveAccessibilityFallbackModifier"
        }
    }

    public var behaviorUse: String {
        switch self {
        case .source:
            return "Current source and freshness labels inside the source trust strip."
        case .sourceAttention:
            return "Source states that require attention before reuse."
        case .privacyBoundary:
            return "Private or protected trust boundary labels."
        case .receipt:
            return "Receipt path and proof-available labels."
        case .accessibilityFallbackSurface:
            return "Opaque primitive surface when Reduce Transparency is active."
        case .accessibilityContrastStroke:
            return "Explicit primitive border when Increase Contrast is active."
        }
    }

    public var accessibilityImplication: String {
        switch self {
        case .source:
            return "Paired with source text and symbol labels; color is not the only state channel."
        case .sourceAttention:
            return "Paired with attention copy, stale or blocked labels, and role symbols."
        case .privacyBoundary:
            return "Paired with privacy/trust copy and lock or shield symbols."
        case .receipt:
            return "Paired with receipt copy and document symbols."
        case .accessibilityFallbackSurface:
            return "Preserves contrast when transparency is reduced."
        case .accessibilityContrastStroke:
            return "Strengthens boundaries for increased contrast without adding a new surface."
        }
    }

    public func color(in theme: AmbitionTheme) -> Color {
        switch self {
        case .source:
            return theme.primitiveSemanticColors.source
        case .sourceAttention:
            return theme.primitiveSemanticColors.sourceAttention
        case .privacyBoundary:
            return theme.primitiveSemanticColors.privacyBoundary
        case .receipt:
            return theme.primitiveSemanticColors.receipt
        case .accessibilityFallbackSurface:
            return theme.primitiveSemanticColors.accessibilityFallbackSurface
        case .accessibilityContrastStroke:
            return theme.primitiveSemanticColors.accessibilityContrastStroke
        }
    }
}
#endif
