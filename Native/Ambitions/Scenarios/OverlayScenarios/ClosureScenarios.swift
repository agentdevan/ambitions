import Foundation

enum ClosureScenarios {
    static let all: [RuntimeScenario] = ScenarioCatalog.stateCoverage(
        for: .externalSurface,
        owner: "closure-overlay",
        states: [.permissionDenied, .recovery, .postMutation]
    )
}
