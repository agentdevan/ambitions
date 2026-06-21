import AmbitionsDesignSystem
import Foundation

struct AmbitionsHaptics {
    let theme: AmbitionTheme

    var primaryActionIntent: AmbitionTheme.HapticIntent { theme.haptics.routeChange }
    var routeChangeIntent: AmbitionTheme.HapticIntent { theme.haptics.routeChange }
    var correctionIntent: AmbitionTheme.HapticIntent { theme.haptics.correction }

    var userInitiatedOnly: Bool { theme.haptics.enabled }

    static let boundary = "Feedback follows explicit user action and never communicates pressure."
}
