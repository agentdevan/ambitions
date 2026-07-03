import Foundation

protocol GoalPathCompiling: Sendable {
    func compile(understanding: GoalUnderstanding) -> GoalCompiledPath
}

struct DefaultGoalPathCompilerService: GoalPathCompiling {
    private let coreCompiler: GoalCompiledPathCompilerCore
    private let packService: any GoalDomainPackApplying

    init(
        coreCompiler: GoalCompiledPathCompilerCore = GoalCompiledPathCompilerCore(),
        packService: any GoalDomainPackApplying = DefaultGoalDomainPackService()
    ) {
        self.coreCompiler = coreCompiler
        self.packService = packService
    }

    func compile(understanding: GoalUnderstanding) -> GoalCompiledPath {
        let compiled = coreCompiler.compile(understanding: understanding)
        return packService.applyPacks(to: compiled, understanding: understanding)
    }
}
