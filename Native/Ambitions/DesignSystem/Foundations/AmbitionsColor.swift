import AmbitionsDesignSystem
import SwiftUI

struct AmbitionsColor {
    let theme: AmbitionTheme

    var canvas: Color { theme.colors.canvas }
    var primaryText: Color { theme.colors.textPrimary }
    var secondaryText: Color { theme.colors.textSecondary }
    var tertiaryText: Color { theme.colors.textTertiary }
    var primaryObjectFill: Color { theme.colors.surfaceOverlay.opacity(0.76) }
    var startHereAccent: Color { theme.colors.accentWarm }
    var trustStroke: Color { theme.colors.strokeSubtle }

    static let rootSurfaceRoles: [String] = [
        "canvas",
        "primaryText",
        "secondaryText",
        "tertiaryText",
        "primaryObjectFill",
        "startHereAccent",
        "trustStroke",
    ]
}
