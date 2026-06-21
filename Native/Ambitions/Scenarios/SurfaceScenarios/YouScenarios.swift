import Foundation

enum YouScenarios {
    static let all: [RuntimeScenario] = ScenarioCatalog.stateCoverage(
        for: .you,
        owner: "you-system-profile"
    )
}
