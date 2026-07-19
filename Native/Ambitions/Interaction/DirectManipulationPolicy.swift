import Foundation

enum DirectManipulationPolicy {
    static func validate(_ grammar: GestureGrammar) -> [String] {
        var issues: [String] = []
        if grammar.semanticAction.isEmpty {
            issues.append("missing-semantic-action")
        }
        if grammar.gesture != .tap && grammar.requiresVisibleControl == false {
            issues.append("missing-visible-control")
        }
        if grammar.accessibilityAlternative.isEmpty {
            issues.append("missing-accessibility-alternative")
        }
        return issues
    }

    static func isAllowed(_ grammar: GestureGrammar) -> Bool {
        validate(grammar).isEmpty
    }
}
