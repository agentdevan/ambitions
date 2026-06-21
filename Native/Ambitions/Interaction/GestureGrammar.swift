import Foundation

enum InteractionGestureKind: String, Sendable, Equatable, CaseIterable {
    case tap
    case longPress
    case drag
    case keyboard
    case voiceOverRotor
}

struct GestureGrammar: Equatable, Sendable {
    let gesture: InteractionGestureKind
    let semanticAction: String
    let requiresVisibleControl: Bool
    let accessibilityAlternative: String

    var isCanonSafe: Bool {
        semanticAction.isEmpty == false &&
            accessibilityAlternative.isEmpty == false &&
            (gesture == .tap || requiresVisibleControl)
    }
}
