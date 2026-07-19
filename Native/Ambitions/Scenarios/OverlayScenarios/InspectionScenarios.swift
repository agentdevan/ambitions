import Foundation

enum InspectionScenarios {
    static let all: [RuntimeScenario] = ScenarioCatalog.stateCoverage(
        for: .trustInspection,
        owner: "trust-inspection"
    )
}
