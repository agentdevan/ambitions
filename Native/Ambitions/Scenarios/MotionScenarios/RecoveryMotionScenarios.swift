import Foundation

enum RecoveryMotionScenarios {
    static let all: [RuntimeScenario] = ScenarioCatalog.stateCoverage(
        for: .stageMotion,
        owner: "recovery-motion",
        states: [.recovery, .offline]
    )
}
