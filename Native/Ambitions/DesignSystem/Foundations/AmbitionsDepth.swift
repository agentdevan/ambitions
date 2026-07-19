import AmbitionsDesignSystem
import SwiftUI

struct AmbitionsDepth {
    let theme: AmbitionTheme

    var primaryObjectShadow: AmbitionTheme.Shadow { theme.depth.resting }
    var raisedObjectShadow: AmbitionTheme.Shadow { theme.depth.raised }
    var overlayShadow: AmbitionTheme.Shadow { theme.depth.overlay }

    func scale(isPressed: Bool) -> CGFloat {
        isPressed ? theme.depth.pressedScale : 1
    }
}
