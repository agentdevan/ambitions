import Foundation

enum CaptureScenarios {
    static let all: [RuntimeScenario] = ScenarioCatalog.stateCoverage(
        for: .captureComposer,
        owner: "capture-composer"
    )
}
