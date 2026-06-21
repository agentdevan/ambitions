import Foundation

enum EmptyStateScenarios {
    static let all: [RuntimeScenario] = ScenarioCatalog.surfaces.flatMap { surface in
        ScenarioCatalog.stateCoverage(
            for: surface,
            owner: "empty-state-stress",
            states: [.empty]
        )
    }
}
