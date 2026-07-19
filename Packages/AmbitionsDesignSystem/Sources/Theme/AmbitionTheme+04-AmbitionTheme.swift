#if canImport(SwiftUI)
import SwiftUI

extension AmbitionTheme {
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
                surfaceOverlay: Color.white.opacity(0.13),
                textPrimary: Color(red: 0.95, green: 0.94, blue: 0.92),
                textSecondary: Color(red: 0.84, green: 0.84, blue: 0.80),
                textTertiary: Color(red: 0.68, green: 0.68, blue: 0.65),
                textInverse: Color(red: 0.10, green: 0.11, blue: 0.14),
                strokeSubtle: Color.white.opacity(0.14),
                strokeStrong: Color.white.opacity(0.24),
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
                surfaceOverlay: Color.black.opacity(0.055),
                textPrimary: Color(red: 0.10, green: 0.11, blue: 0.14),
                textSecondary: Color(red: 0.24, green: 0.26, blue: 0.30),
                textTertiary: Color(red: 0.38, green: 0.40, blue: 0.44),
                textInverse: Color.white,
                strokeSubtle: Color.black.opacity(0.12),
                strokeStrong: Color.black.opacity(0.20),
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
                headerMaterial: LinearGradient(
                    colors: [
                        Color(red: 0.130, green: 0.138, blue: 0.166),
                        Color(red: 0.082, green: 0.090, blue: 0.116)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
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
                glass: ShellGlassTokens(
                    controlGlass: Glass.regular.interactive(true).tint(accent.secondary.opacity(0.18)),
                    headerGlass: Glass.regular.interactive(false).tint(accent.warm.opacity(0.12)),
                    bottomBarGlass: Glass.regular.interactive(false).tint(accent.warm.opacity(0.10)),
                    containerSpacing: 14
                ),
                activeTabForeground: accent.warm,
                activeTabBackground: accent.warm.opacity(0.18),
                inactiveTabForeground: Color(red: 0.72, green: 0.78, blue: 0.84),
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
                headerMaterial: LinearGradient(
                    colors: [
                        Color(red: 1.000, green: 0.992, blue: 0.972),
                        Color(red: 0.955, green: 0.940, blue: 0.912)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
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
                glass: ShellGlassTokens(
                    controlGlass: Glass.regular.interactive(true).tint(accent.secondary.opacity(0.12)),
                    headerGlass: Glass.regular.interactive(false).tint(accent.warm.opacity(0.08)),
                    bottomBarGlass: Glass.regular.interactive(false).tint(accent.warm.opacity(0.08)),
                    containerSpacing: 14
                ),
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
#endif
