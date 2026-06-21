import Foundation

enum PostMutationMotionScenarios {
    static let all: [RuntimeScenario] = ScenarioCatalog.stateCoverage(
        for: .stageMotion,
        owner: "post-mutation-motion",
        states: [.postMutation]
    )
}
