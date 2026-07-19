import Foundation

enum PostMutationScenarios {
    static let all: [RuntimeScenario] = ScenarioCatalog.surfaces.flatMap { surface in
        ScenarioCatalog.stateCoverage(
            for: surface,
            owner: "post-mutation-stress",
            states: [.postMutation]
        )
    }
}
