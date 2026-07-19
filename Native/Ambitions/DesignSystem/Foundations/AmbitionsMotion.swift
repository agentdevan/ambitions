import AmbitionsDesignSystem
import SwiftUI

struct AmbitionsMotion {
    let theme: AmbitionTheme

    func primaryObjectTransition(reduceMotion: Bool) -> AnyTransition {
        DAVMotionPreset.heroExpansion.transition(reduceMotion: reduceMotion)
    }

    func routeAnimation(reduceMotion: Bool) -> Animation? {
        theme.motion.routeAnimation(reduceMotion: reduceMotion)
    }

    static let reductionContract = "Reduce Motion keeps meaning in visible state and accessibility labels."
}
