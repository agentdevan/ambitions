import Foundation

enum StageMotionScenarios {
    static let all: [RuntimeScenario] = ScenarioCatalog.stateCoverage(
        for: .stageMotion,
        owner: "stage-motion"
    )
}
