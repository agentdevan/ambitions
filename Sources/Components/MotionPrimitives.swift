#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionMotionPattern: Sendable {
    case completion
    case correction
    case reschedule
    case routeChange
    case panelEntry
}

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
}

public extension View {
    @ViewBuilder
    func ambitionHaptic<T: Equatable>(
        _ intent: AmbitionTheme.HapticIntent,
        trigger: T
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            sensoryFeedback(hapticFeedback(for: intent), trigger: trigger)
        } else {
            self
        }
    }

    @available(iOS 17.0, macOS 14.0, *)
    private func hapticFeedback(for intent: AmbitionTheme.HapticIntent) -> SensoryFeedback {
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
