import AmbitionsDesignSystem
import SwiftUI

struct AmbitionsLighting {
    let theme: AmbitionTheme

    var startHereAccentOpacity: Double { theme.mode == .dark ? 0.86 : 0.72 }
    var startHereWashBlendMode: BlendMode { .screen }
    var proofGlow: Color { theme.colors.accentWarm.opacity(0.10) }

    static let rootObjectRule = "Lighting clarifies the primary object without becoming decoration."
}
