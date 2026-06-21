import Foundation

enum SearchScenarios {
    static let all: [RuntimeScenario] = ScenarioCatalog.stateCoverage(
        for: .externalSurface,
        owner: "search-overlay",
        states: [.normal, .dense, .offline, .postMutation]
    )
}
