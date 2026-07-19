import Foundation

enum DenseStateScenarios {
    static let all: [RuntimeScenario] = ScenarioCatalog.surfaces.flatMap { surface in
        ScenarioCatalog.stateCoverage(
            for: surface,
            owner: "dense-state-stress",
            states: [.dense]
        )
    }
}
