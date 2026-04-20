import Foundation

protocol GoalResourceGraphBuilding: Sendable {
    func build(
        compiledPath: GoalCompiledPath,
        knowledgeContext: GoalUnderstandingKnowledgeContext?
    ) -> GoalResourceGraph
}

struct DefaultGoalResourceGraphService: GoalResourceGraphBuilding {
    private let core: GoalResourceGraphBuilderCore

    init(core: GoalResourceGraphBuilderCore = GoalResourceGraphBuilderCore()) {
        self.core = core
    }

    func build(
        compiledPath: GoalCompiledPath,
        knowledgeContext: GoalUnderstandingKnowledgeContext?
    ) -> GoalResourceGraph {
        core.build(
            compiledPath: compiledPath,
            knowledgeContext: knowledgeContext
        )
    }
}
