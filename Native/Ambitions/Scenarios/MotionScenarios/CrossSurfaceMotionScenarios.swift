import Foundation

enum CrossSurfaceMotionScenarios {
    static let all: [RuntimeScenario] = [
        .today,
        .goals,
        .time,
        .you
    ].flatMap { surface in
        ScenarioCatalog.accessibilityCoverage(
            for: surface,
            owner: "cross-surface-motion",
            modes: [.reduceMotion]
        )
    }
}
