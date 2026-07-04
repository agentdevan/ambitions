import Foundation

protocol GoalResourceGraphBuilding: Sendable {
    func build(
        compiledPath: GoalCompiledPath,
        knowledgeContext: GoalUnderstandingKnowledgeContext?,
        referenceNow: String?
    ) -> GoalResourceGraph
}

extension GoalResourceGraphBuilding {
    func build(
        compiledPath: GoalCompiledPath,
        knowledgeContext: GoalUnderstandingKnowledgeContext?
    ) -> GoalResourceGraph {
        build(
            compiledPath: compiledPath,
            knowledgeContext: knowledgeContext,
            referenceNow: nil
        )
    }
}

struct DefaultGoalResourceGraphService: GoalResourceGraphBuilding {
    private let core: GoalResourceGraphBuilderCore
    private let freshnessService: any GoalFreshnessUpdateEvaluating

    init(
        core: GoalResourceGraphBuilderCore = GoalResourceGraphBuilderCore(),
        freshnessService: any GoalFreshnessUpdateEvaluating = DefaultGoalFreshnessUpdateService()
    ) {
        self.core = core
        self.freshnessService = freshnessService
    }

    func build(
        compiledPath: GoalCompiledPath,
        knowledgeContext: GoalUnderstandingKnowledgeContext?,
        referenceNow: String?
    ) -> GoalResourceGraph {
        let graph = core.build(
            compiledPath: compiledPath,
            knowledgeContext: knowledgeContext
        )
        return freshnessService.annotate(
            graph: graph,
            knowledgeContext: knowledgeContext,
            referenceNow: referenceNow
        )
    }
}
