import AmbitionsDesignSystem
import SwiftUI

struct AmbitionsMaterial {
    let theme: AmbitionTheme

    var startHereWash: LinearGradient {
        LinearGradient(
            colors: [
                theme.colors.accentWarm.opacity(0.14),
                theme.colors.surfaceOverlay.opacity(0.02),
                .clear,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var canvas: LinearGradient { theme.materials.canvasGradient }
    var elevated: LinearGradient { theme.materials.elevatedGradient }
    var overlay: LinearGradient { theme.materials.overlayGradient }
}
