#if canImport(SwiftUI)
import SwiftUI

// accessibilityReduceMotion contract: Stage/Surface callers pass the Reduce Motion environment into every motion token here.
public extension AnyTransition {
    static var ambitionPanel: AnyTransition {
        ambitionTransition(.panelEntry)
    }

    static func ambitionTransition(_ pattern: AmbitionMotionPattern) -> AnyTransition {
        switch pattern {
        case .completion:
            return .asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .center)),
                removal: .opacity.combined(with: .scale(scale: 0.96, anchor: .center))
            )
        case .correction:
            return .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .top)),
                removal: .opacity
            )
        case .reschedule:
            return .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .trailing)),
                removal: .opacity.combined(with: .move(edge: .leading))
            )
        case .routeChange:
            return .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .trailing)),
                removal: .opacity.combined(with: .move(edge: .leading))
            )
        case .panelEntry:
            return .asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.985, anchor: .top)),
                removal: .opacity.combined(with: .scale(scale: 0.99, anchor: .top))
            )
        }
    }

    static func ambitionInteraction(
        _ token: AmbitionInteractionToken,
        reduceMotion: Bool
    ) -> AnyTransition {
        token.davMotionPreset.transition(reduceMotion: reduceMotion)
    }
}

public extension Animation {
    static func ambitionMotion(
        _ pattern: AmbitionMotionPattern,
        theme: AmbitionTheme,
        reduceMotion: Bool
    ) -> Animation? {
        switch pattern {
        case .routeChange:
            return theme.motion.routeAnimation(reduceMotion: reduceMotion)
        case .completion, .correction, .reschedule, .panelEntry:
            return theme.motion.animation(reduceMotion: reduceMotion, emphasis: pattern == .panelEntry)
        }
    }

    static func ambitionInteraction(
        _ token: AmbitionInteractionToken,
        theme: AmbitionTheme,
        reduceMotion: Bool
    ) -> Animation? {
        token.davMotionPreset.animation(theme: theme, reduceMotion: reduceMotion)
    }
}

public extension View {
    @ViewBuilder
    func ambitionHaptic<T: Equatable>(
        _ intent: AmbitionTheme.HapticIntent,
        trigger: T
    ) -> some View {
        sensoryFeedback(hapticFeedback(for: intent), trigger: trigger)
    }

    @ViewBuilder
    func ambitionInteractionHaptic<T: Equatable>(
        _ token: AmbitionInteractionToken,
        trigger: T,
        isEnabled: Bool = true
    ) -> some View {
        if isEnabled, let intent = token.hapticPolicy.intent {
            ambitionHaptic(intent, trigger: trigger)
        } else {
            self
        }
    }

    func hapticFeedback(for intent: AmbitionTheme.HapticIntent) -> SensoryFeedback {
        switch intent {
        case .selection, .routeChange:
            return .selection
        case .completion:
            return .success
        case .correction:
            return .alignment
        case .reschedule:
            return .impact(weight: .light, intensity: 0.75)
        case .warning:
            return .warning
        }
    }
}
#endif
