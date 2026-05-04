#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionMotionPattern: CaseIterable, Sendable {
    case completion
    case correction
    case reschedule
    case routeChange
    case panelEntry
}

public enum AmbitionInteractionPurpose: String, CaseIterable, Sendable {
    case orientation
    case confirmation
    case uncertaintyReduction

    public var title: String {
        switch self {
        case .orientation:
            return "Orientation"
        case .confirmation:
            return "Confirmation"
        case .uncertaintyReduction:
            return "Uncertainty reduction"
        }
    }
}

public enum AmbitionHapticPolicy: Equatable, Sendable {
    case none
    case userInitiated(AmbitionTheme.HapticIntent)

    public var intent: AmbitionTheme.HapticIntent? {
        switch self {
        case .none:
            return nil
        case .userInitiated(let intent):
            return intent
        }
    }
}

public enum AmbitionInteractionToken: String, CaseIterable, Sendable {
    case routeOrientation
    case panelReveal
    case selectionConfirm
    case proofConfirm
    case correctionNeeded
    case sourceCheck
    case reviewRequired
    case privacyBoundary
    case unsafeRedirect
    case recompilePending
    case localOnlySettle

    public var purpose: AmbitionInteractionPurpose {
        switch self {
        case .routeOrientation, .panelReveal, .recompilePending:
            return .orientation
        case .selectionConfirm, .proofConfirm:
            return .confirmation
        case .correctionNeeded, .sourceCheck, .reviewRequired, .privacyBoundary, .unsafeRedirect, .localOnlySettle:
            return .uncertaintyReduction
        }
    }

    public var motionPattern: AmbitionMotionPattern {
        switch self {
        case .routeOrientation:
            return .routeChange
        case .panelReveal, .privacyBoundary:
            return .panelEntry
        case .selectionConfirm, .proofConfirm:
            return .completion
        case .correctionNeeded, .reviewRequired, .unsafeRedirect:
            return .correction
        case .sourceCheck, .recompilePending:
            return .reschedule
        case .localOnlySettle:
            return .panelEntry
        }
    }

    public var davMotionPreset: DAVMotionPreset {
        switch self {
        case .routeOrientation:
            return .railProgress
        case .panelReveal, .privacyBoundary:
            return .softReveal
        case .selectionConfirm, .localOnlySettle:
            return .stateSettle
        case .proofConfirm:
            return .receiptConfirmation
        case .correctionNeeded, .sourceCheck, .reviewRequired, .unsafeRedirect, .recompilePending:
            return .stateSettle
        }
    }

    public var hapticPolicy: AmbitionHapticPolicy {
        switch self {
        case .selectionConfirm:
            return .userInitiated(.selection)
        case .proofConfirm:
            return .userInitiated(.completion)
        case .routeOrientation:
            return .userInitiated(.routeChange)
        case .correctionNeeded:
            return .userInitiated(.correction)
        case .panelReveal, .sourceCheck, .reviewRequired, .privacyBoundary, .unsafeRedirect, .recompilePending, .localOnlySettle:
            return .none
        }
    }

    public var title: String {
        switch self {
        case .routeOrientation:
            return "Route orientation"
        case .panelReveal:
            return "Panel reveal"
        case .selectionConfirm:
            return "Selection confirmed"
        case .proofConfirm:
            return "Proof confirmed"
        case .correctionNeeded:
            return "Correction needed"
        case .sourceCheck:
            return "Source check"
        case .reviewRequired:
            return "Review required"
        case .privacyBoundary:
            return "Privacy boundary"
        case .unsafeRedirect:
            return "Unsafe redirect"
        case .recompilePending:
            return "Recompile pending"
        case .localOnlySettle:
            return "Local-only settle"
        }
    }

    public var reduceMotionEquivalent: String {
        switch self {
        case .routeOrientation:
            return "Immediate destination title, preserved back path, and selected row label."
        case .panelReveal:
            return "Instant panel reveal with unchanged hierarchy and status text."
        case .selectionConfirm:
            return "Static selected label, symbol, and VoiceOver value."
        case .proofConfirm:
            return "Static receipt/proof label with source and undo or correction text."
        case .correctionNeeded:
            return "Static correction label and next action without shake or reward motion."
        case .sourceCheck:
            return "Static source-state label before any commitment can move."
        case .reviewRequired:
            return "Static review label and explicit user-review affordance."
        case .privacyBoundary:
            return "Static privacy label with no private-detail reveal."
        case .unsafeRedirect:
            return "Static safety redirect label and professional-boundary copy."
        case .recompilePending:
            return "Static impact label that says review is needed before changes apply."
        case .localOnlySettle:
            return "Static local-only label and unchanged data-boundary text."
        }
    }

    public var accessibilitySummary: String {
        "\(title). \(purpose.title). Reduce Motion: \(reduceMotionEquivalent)"
    }

    public var allowsAutomaticHaptics: Bool {
        hapticPolicy.intent != nil
    }
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
        if #available(iOS 17.0, macOS 14.0, *) {
            sensoryFeedback(hapticFeedback(for: intent), trigger: trigger)
        } else {
            self
        }
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
