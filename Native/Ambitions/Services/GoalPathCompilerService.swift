import Foundation

protocol GoalPathCompiling: Sendable {
    func compile(understanding: GoalUnderstanding) -> GoalCompiledPath
}

struct DefaultGoalPathCompilerService: GoalPathCompiling {
    func compile(understanding: GoalUnderstanding) -> GoalCompiledPath {
        GoalCompiledPath.legacyFallback(from: understanding)
    }
}
