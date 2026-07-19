import Foundation

enum BrokenSourceScenarios {
    static let all: [RuntimeScenario] = ScenarioCatalog.surfaces.flatMap { surface in
        ScenarioCatalog.stateCoverage(
            for: surface,
            owner: "broken-source-stress",
            states: [.brokenSource, .offline, .permissionDenied]
        )
    }
}
